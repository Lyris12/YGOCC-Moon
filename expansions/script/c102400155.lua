--created & coded by Lyris, art from Shadowverse's "Wood of Brambles" & "Siren's Tears"
--RUM－ワンドラス・フォース
local s,id,off=GetID()
function s.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
function s.filter1(c,e,tp)
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	return c:IsXyzSummonable(nil) and (not ect or ect>1)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.filter2(c,e,tp,mc)
	return c:IsRace(mc:GetRace()) and c:IsAttribute(mc:GetAttribute())
		and mc:IsCanBeXyzMaterial(c) and c:IsRank(mc:GetRank()+1)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.filter3(c,sc,f)
	return c:IsCanBeXyzMaterial(sc) and (not f or f(c))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	tc1:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetOperation(function()
		e1:Reset() e2:Reset()
		if Duel.GetLocationCountFromEx(tp,tp,tc1)<=0 or not aux.MustMaterialCheck(tc1,tp,EFFECT_MUST_BE_XMATERIAL) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc1,tc1:GetRace(),tc1:GetAttribute())
		local tc2=g2:GetFirst()
		if tc2 then
			Duel.BreakEffect()
			local xmg=tc1:GetOverlayGroup()
			if #xmg~=0 then
				Duel.Overlay(tc2,xmg)
			end
			tc2:SetMaterial(g1)
			Duel.Overlay(tc2,tc1)
			Duel.SpecialSummon(tc2,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			tc2:CompleteProcedure()
		end
	end)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	tc1:RegisterEffect(e2,true)
	Duel.XyzSummon(tp,tc1,nil)
end
