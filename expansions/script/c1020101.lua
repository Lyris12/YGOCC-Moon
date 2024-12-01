--[[
Galactic CODE Upgrade
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_FUSION_SUMMON|CATEGORY_DECKDES|CATEGORY_GRAVE_ACTION|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetCost(aux.PayLPCost(1000))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.fusion_effect=true

function s.mfilter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
function s.mfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function s.spfilter1(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsSetCard(ARCHE_CODE_JAKE) and s.spfilter1(c,e,tp,m,f,chkf)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		local res=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if res then return true end
		local deck=Duel.GetMatchingGroup(s.mfilter1,tp,LOCATION_DECK,0,nil)
		local deckcon=Duel.IsExistingMatchingCard(Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
		if deckcon then
			mg1:Merge(deck)
		end
		
		local gy=Duel.GetMatchingGroup(s.mfilter2,tp,LOCATION_GRAVE,0,nil)
		local gycon=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)
		if gycon then
			mg1:Merge(gy)
		end
		
		res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg0=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	local mg1=mg0:Clone()
	
	local deck=Duel.GetMatchingGroup(s.mfilter1,tp,LOCATION_DECK,0,nil)
	local deckcon=Duel.IsExistingMatchingCard(Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
	if deckcon then
		mg1:Merge(deck)
	end
	
	local gy=Duel.GetMatchingGroup(s.mfilter2,tp,LOCATION_GRAVE,0,nil)
	local gycon=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)
	if gycon then
		mg1:Merge(gy)
	end
	
	local sg0=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg0,nil,chkf)
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	
	if #sg0+#sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg0:Clone()
		sg:Merge(sg1)
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if (sg0:IsContains(tc) or sg1:IsContains(tc)) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mg=sg1:IsContains(tc) and mg1 or mg0
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat1)
			local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(mat2)
			Duel.SendtoGrave(mat1,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
			Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end