--Dimenticalgia Incarnazione Incubo
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cid.lcheck)
	c:EnableReviveLimit()
	--synchro summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(cid.syntg)
	e1:SetOperation(cid.synop)
	c:RegisterEffect(e1)
end
--filters
function cid.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xf45)
end
function cid.filter1(c,e,tp)
	local lv=c:GetLevel()
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp,lv)
end
function cid.filter2(c,tp,lv)
	if c:GetLevel()<=0 then return false end
	local rlv=lv-c:GetLevel()
	local rg=Duel.GetMatchingGroup(cid.filter3,tp,LOCATION_MZONE+LOCATION_GRAVE,0,c,tp)
	if Duel.GetLocationCountFromEx(tp,tp,c)>0 then
		return c:IsSetCard(0xf45) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
			and ((rlv>0 and rg:CheckWithSumEqual(Card.GetLevel,rlv,1,63)) or rlv==0)
	elseif rg:IsExists(cid.checkEMZ,1,nil,tp) then
		local emz=rg:Filter(cid.checkEMZsum,nil,tp,rg,rlv)
		return c:IsSetCard(0xf45) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
			and (rlv>0 and emz:GetCount()>0)
	else
		return false
	end
end
function cid.filter3(c)
	return c:GetLevel()>0 and c:IsSetCard(0xf45) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() 
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
end
function cid.checkEMZ(c,tp)
	return Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function cid.checkEMZsum(c,tp,rg,rlv)
	if rg:IsContains(c) then
		local sg=rg:Clone()
		sg:RemoveCard(c)
		return Duel.GetLocationCountFromEx(tp,tp,c)>0 and sg:CheckWithSumEqual(Card.GetLevel,rlv-c:GetLevel(),1,63)
	else
		return Duel.GetLocationCountFromEx(tp,tp,c)>0 and rg:CheckWithSumEqual(Card.GetLevel,rlv-c:GetLevel(),1,63)
	end
end
--synchro summon
function cid.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function cid.synop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(cid.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) then return end
	if aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g1=Duel.SelectMatchingCard(tp,cid.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local lv=g1:GetFirst():GetLevel()
		local ok=false
		local g2
		while ok==false do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			g2=Duel.SelectMatchingCard(tp,cid.filter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp,lv)
			ok=Duel.SelectYesNo(tp,aux.Stringid(id,1))
		end
		local rlv=lv-g2:GetFirst():GetLevel()
		if rlv>0 then
			if Duel.GetLocationCountFromEx(tp,tp,g2:GetFirst())>0 then
				local rg=Duel.GetMatchingGroup(cid.filter3,tp,LOCATION_MZONE+LOCATION_GRAVE,0,g2:GetFirst())
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local g3=rg:SelectWithSumEqual(tp,Card.GetLevel,rlv,1,63)
				g2:Merge(g3)
			else
				local rg=Duel.GetMatchingGroup(cid.filter3,tp,LOCATION_MZONE+LOCATION_GRAVE,0,g2:GetFirst())
				local emz=rg:Filter(cid.checkEMZsum,nil,tp,rg,rlv)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local emzcheck=emz:Select(tp,1,1,nil)
				g2:Merge(emzcheck)
				rlv=rlv-emzcheck:GetFirst():GetLevel()
				if rlv>0 then
					rg:RemoveCard(emzcheck:GetFirst())
					local g3=rg:SelectWithSumEqual(tp,Card.GetLevel,rlv,1,63)
					g2:Merge(g3)
				end
			end
		end
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		if Duel.SpecialSummon(g1,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)~=0 then
			g1:GetFirst():CompleteProcedure()
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end