--created & coded by Lyris, art from Shadowverse's "Wood of Brambles" & "Siren's Tears"
--RUM－ワンドラス・フォース
local cid,id=GetID()
function cid.initial_effect(c)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.activate)
	c:RegisterEffect(e2)
end
function cid.filter1(c,e,tp)
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	return c:IsXyzSummonable(nil) and (not ect or ect>1)
		and Duel.IsExistingMatchingCard(cid.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function cid.filter2(c,e,tp,mc)
	return c:IsRace(mc:GetRace()) and c:IsAttribute(mc:GetAttribute())
		and mc:IsCanBeXyzMaterial(c) and c:IsRank(mc:GetRank()+1)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.GetLocationCountFromEx(tp)>0
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(cid.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function cid.filter3(c,sc,f)
	return c:IsCanBeXyzMaterial(sc) and (not f or f(c))
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,cid.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc1=g1:GetFirst()
	local mt=getmetatable(tc1)
	local mg=Duel.SelectXyzMaterial(tp,tc1,aux.FilterBoolFunction(cid.filter3,tc1,mt.material_filter),tc1:GetRank(),mt.material_minct,mt.material_maxct)
	local sg=Group.CreateGroup()
	local tc=mg:GetFirst()
	while tc do
		local sg1=tc:GetOverlayGroup()
		sg:Merge(sg1)
		tc=mg:GetNext()
	end
	Duel.SendtoGrave(sg,REASON_RULE)
	tc1:SetMaterial(mg)
	Duel.Overlay(tc1,mg)
	if tc1 and Duel.SpecialSummon(tc1,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
		tc1:CompleteProcedure()
		if Duel.GetLocationCountFromEx(tp,tp,tc1)<=0 then return end
		if not aux.MustMaterialCheck(tc1,tp,EFFECT_MUST_BE_XMATERIAL) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,cid.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc1,tc1:GetRace(),tc1:GetAttribute())
		local tc2=g2:GetFirst()
		if tc2 then
			Duel.BreakEffect()
			local xmg=tc1:GetOverlayGroup()
			if xmg:GetCount()~=0 then
				Duel.Overlay(tc2,xmg)
			end
			tc2:SetMaterial(g1)
			Duel.Overlay(tc2,g1)
			Duel.SpecialSummon(tc2,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
			tc2:CompleteProcedure()
		end
	end
end
