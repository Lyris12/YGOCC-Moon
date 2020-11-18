--created & coded by Lyris
--RUM－チェーン・フォース
local s,id=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.filter0(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.filter1(c,e,tp)
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	return (c:IsOnField() and c:IsCanBeEffectTarget(e) or (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not ect or ect>1)))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.filter2(c,e,tp,mc)
	local brk,rk=c:GetRank(),mc:GetRank()
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	return c:GetRace()==mc:GetRace() and c:GetAttribute()==mc:GetAttribute() and mc:IsCanBeXyzMaterial(c)
		and (not ect or ect>0) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and (brk==rk+1 or brk==rk+2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_MZONE
	local ect=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
		and aux.ExtraDeckSummonCountLimit[tp]
	if Duel.GetLocationCountFromEx(tp)>0 and (ect==nil or ect>1) and not Duel.IsExistingMatchingCard(s.filter0,tp,LOCATION_MZONE,0,1,nil) then loc=loc+LOCATION_EXTRA end
	if chk==0 then e:SetLabel(0) return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.GetFlagEffect(tp,id)==0 and (Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(s.filter1,tp,loc,0,1,nil,e,tp)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	if #g1>0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	else e:SetLabel(1) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	local tc0=Duel.GetFirstTarget()
	for i=0,1 do
		local ect=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
			and aux.ExtraDeckSummonCountLimit[tp]
		if Duel.GetLocationCountFromEx(tp)>0 and (ect==nil or ect>1) and i==0 and e:GetLabel()~=0 then 
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
			local tc1=g1:GetFirst()
			if Duel.SpecialSummon(tc1,0,tp,tp,false,false,POS_FACEUP)~=0 then tc0=tc1 end
		end
		if tc0 then
			if Duel.GetLocationCountFromEx(tp,tp,tc0)<=0 or not aux.MustMaterialCheck(tc0,tp,EFFECT_MUST_BE_XMATERIAL) then break end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc0)
			local tc2=g2:GetFirst()
			if tc2 then
				Duel.BreakEffect()
				local g1=Group.FromCards(tc0)
				tc2:SetMaterial(g1)
				Duel.Overlay(tc2,tc0:GetOverlayGroup())
				Duel.Overlay(tc2,g1)
				Duel.SpecialSummon(tc2,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
				tc2:CompleteProcedure()
				if i~=0 or not tc2:IsCanBeEffectTarget(e) or not Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc2)
					or (c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]==0)
					or (ect~=nil and ect<=1) or not Duel.SelectEffectYesNo(tp,e:GetHandler()) then break end
				Duel.HintSelection(Group.FromCards(tc2))
				tc0=tc2
			else break end
		else break end
	end
end
