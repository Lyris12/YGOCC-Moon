--created & coded by Lyris
--フェイツ出会い
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.spfilter(c,e,tp,mc1,mc2)
	local trap=c:IsType(TYPE_TRAP)
	return c:IsSetCard(0xf7a) and (trap or c:GetType()&0x81==0x81) and (not c.mat_filter or c.mat_filter(mc,tp))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,trap,true)
		and mc1:IsCanBeRitualMaterial(c) and mc2:IsCanBeRitualMaterial(c)
end
function cid.rfilter(c,mc1,mc2)
	local mlv1,mlv2=mc1:GetRitualLevel(c),mc2:GetRitualLevel(c)
	if mlv1==mc1:GetLevel() and mlv2==mc2:GetLevel() then return false end
	local lv=c:IsType(TYPE_TRAP) and c:GetOriginalLevel() or c:GetLevel()
	return lv==bit.band(mlv1+mlv2,0xffff) or lv==bit.rshift(mlv1+mlv2,16)
end
function cid.filter(c,e,tp,mg)
	return mg:IsExists(cid.filter2,1,nil,e,tp,c)
end
function cid.filter2(c,e,tp,mc)
	if (c:IsLevelAbove(1) and mc:IsLevelAbove(1)) or not (c:IsLevelAbove(1) and mc:IsLevelAbove(1)) then return false end
	local i1,i2
	if c:GetLevel()>0 then i1,i2=c:GetLevel(),Duel.ReadCard(mc,CARDDATA_LEVEL)
	else i1,i2=Duel.ReadCard(c,CARDDATA_LEVEL),mc:GetLevel() end
	if c:IsType(TYPE_EVOLUTE) then i1=1 end
	if mc:IsType(TYPE_EVOLUTE) then i2=1 end
	local sg=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_HAND,0,c,e,tp,c,mc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	if Duel.IsPlayerAffectedByEffect(tp,id) then ft=1 end
	return sg:IsExists(cid.rfilter,1,nil,c,mc) or sg:CheckWithSumGreater(Card.GetLevel,i1+i2,1,ft)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return false end
		local mg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,nil)
		return mg:IsExists(cid.filter,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function cid.lvfun(c)
	if c:IsType(TYPE_TRAP) then return c:GetOriginalLevel()
	else return c:GetLevel() end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local mg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local mat=mg:FilterSelect(tp,cid.filter,1,1,nil,e,tp,mg)
	local mc=mat:GetFirst()
	if not mc then return end
	local mc2=mg:FilterSelect(tp,cid.filter2,1,1,nil,e,tp,mc):GetFirst()
	local sg=Duel.GetMatchingGroup(cid.spfilter,tp,LOCATION_HAND,0,mc,e,tp,mc,mc2)
	if mc:IsLocation(LOCATION_MZONE) then ft=ft+1 end
	if Duel.IsPlayerAffectedByEffect(tp,id) then ft=1 end
	local b1=sg:IsExists(cid.rfilter,1,nil,mc,mc2)
	local i1,i2
	if mc:GetLevel()>0 then i1,i2=mc:GetLevel(),Duel.ReadCard(mc2,CARDDATA_LEVEL)
	else i1,i2=Duel.ReadCard(mc,CARDDATA_LEVEL),mc2:GetLevel() end
	local b2=sg:CheckWithSumGreater(cid.lvfun,i1+i2,1,ft)
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:FilterSelect(tp,cid.rfilter,1,1,nil,mc,mc2)
		local tc=tg:GetFirst()
		tc:SetMaterial(mat)
		Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_REMOVE_TYPE)
		e1:SetValue(TYPE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,tc:IsType(TYPE_TRAP),true,POS_FACEUP)
		tc:CompleteProcedure()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:SelectWithSumGreater(tp,cid.lvfun,i1+i2,1,ft)
		local tc=tg:GetFirst()
		while tc do
			tc:SetMaterial(mat)
			tc=tg:GetNext()
		end
		Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		local fg=tg:Filter(Card.IsFacedown,nil)
		if #fg>0 then Duel.ConfirmCards(1-tp,fg) end
		for tc in aux.Next(tg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_REMOVE_TYPE)
			e1:SetValue(TYPE_EFFECT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			tc:RegisterEffect(e1)
			Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,tc:IsType(TYPE_TRAP),true,POS_FACEUP)
			tc:CompleteProcedure()
		end
		Duel.SpecialSummonComplete()
	end
end
