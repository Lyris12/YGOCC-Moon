--created by Walrus, coded by XGlitchy30
--Voidictator Energy - Ritual Essence
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.RitualUltimateTarget)
	e1:SetOperation(s.RitualUltimateOperation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:HOPT(nil,2)
	e2:SetCondition(s.thcon)
	e2:SetCost(aux.BanishCost(s.cfilter,LOCATION_HAND|LOCATION_GRAVE))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
function s.matfilter(c)
	return c:IsAttributeRace(ATTRIBUTE_DARK,RACE_FIEND)
end
function s.RitualExtraFilter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsLevelBelow(4) and c:IsType(TYPE_MONSTER) and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_FIEND)
end
function s.RitualUltimateFilter(c,e,tp,m1,m2)
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsSetCard(ARCHE_VOIDICTATOR) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=c:GetLevel()
	Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(c,lv,"Greater")
	local res=mg:CheckSubGroup(Auxiliary.RitualCheck,1,lv,tp,c,lv,"Greater")
	Auxiliary.GCheckAdditional=nil
	return res
end
function s.RitualUltimateTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp):Filter(s.matfilter,nil)
		local exg=Duel.GetMatchingGroup(s.RitualExtraFilter,tp,LOCATION_REMOVED,0,nil)
		return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg,exg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.RitualUltimateOperation(e,tp,eg,ep,ev,re,r,rp)
	::RitualUltimateSelectStart::
	local mg=Duel.GetRitualMaterial(tp):Filter(s.matfilter,nil)
	local exg=Duel.GetMatchingGroup(s.RitualExtraFilter,tp,LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,Auxiliary.NecroValleyFilter(s.RitualUltimateFilter),tp,LOCATION_HAND,0,1,1,nil,e,tp,mg,exg)
	local tc=tg:GetFirst()
	local mat
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if exg then
			mg:Merge(exg)
		end
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local lv=tc:GetLevel()
		Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(tc,lv,"Greater")
		mat=mg:SelectSubGroup(tp,Auxiliary.RitualCheck,true,1,lv,tp,tc,lv,"Greater")
		Auxiliary.GCheckAdditional=nil
		if not mat then goto RitualUltimateSelectStart end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_REMOVED):Filter(s.RitualExtraFilter,nil)
		mat:Sub(mat2)
		Duel.ReleaseRitualMaterial(mat)
		if #mat2>0 then
			Duel.HintSelection(mat2)
			Duel.SendtoGrave(mat2,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL|REASON_RETURN)
		end
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_VOIDICTATOR_SERVANT)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Search(c,tp)
	end
end
