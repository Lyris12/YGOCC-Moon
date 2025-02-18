--[[
Nullfinite Amalgam
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your Main Phase, or when your opponent Special Summons a Fusion Monster (in which case this is a Quick Effect), while this card is banished (except during the Damage Step): You can
	activate this effect; Fusion Summon 1 DARK Fiend Fusion Monster from your Extra Deck, by shuffling your face-up banished monsters into the Deck as materials, including this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_FUSION_SUMMON|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_REMOVED)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetLabelObject(aux.AddThisCardBanishedAlreadyCheck(c))
	e1a:SetCondition(aux.AlreadyInRangeEventCondition(s.cfilter))
	c:RegisterEffect(e1a)
	--[[If this card is banished, except from the Deck: You can target 1 monster in your GY; banish it.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetSendtoFunctions(LOCATION_REMOVED,TGCHECK_IT,Card.IsMonster,LOCATION_GRAVE,0,1,1,nil)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSummonPlayer(1-tp)
end
function s.filter0(c,e)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
function s.filter1(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_FIEND) and (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	local res=c:CheckFusionMaterial(m,e:GetHandler(),chkf)
	return res
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_REMOVED,0,nil,e)
		local res=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	local mg=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_REMOVED,0,nil,e)
	local sg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,e:GetHandler(),chkf)
			tc:SetMaterial(mat1)
			Duel.HintSelection(mat1)
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,e:GetHandler(),chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end