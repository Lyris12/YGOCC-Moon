--Zinnia the Lightning Esprision
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--You can reveal 1 other "Esprision" monster in your hand; Special Summon this card from your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(aux.RevealCost(aux.MonsterFilter(Card.IsSetCard,0xe50),1,1,true))
	e1:SetTarget(aux.SSSelfTarget())
	e1:SetOperation(aux.SSSelfOperation())
	c:RegisterEffect(e1)
	--During your opponent's turn (Quick Effect): You can roll a six-sided die and apply the result. 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DICE|CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetHintTiming(0,RELEVANT_TIMINGS)
	e2:SetCondition(aux.TurnPlayerCond(1))
	e2:SetTarget(s.dctg)
	e2:SetOperation(s.dcop)
	c:RegisterEffect(e2)
end
s.toss_dice=true

function s.thfilter(c)
	return c:IsType(TYPE_ST) and c:IsSetCard(0xe50)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xe50) and c:IsMonster(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local lower = Duel.IsPlayerCanSendtoHand(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local upper = Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and c:IsCanOverlay(tp)
		return lower or upper
	end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d<=3 then
		local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
		local dcount=#g
		if dcount==0 then return end
		local sg=g:Filter(s.thfilter,nil)
		if #sg==0 then
			Duel.ConfirmDecktop(tp,dcount)
			Duel.ShuffleDeck(tp)
			return
		end
		local seq=-1
		local thcard=nil
		for tc in aux.Next(sg) do
			if tc:GetSequence()>seq then 
				seq=tc:GetSequence()
				thcard=tc
			end
		end
		Duel.ConfirmDecktop(tp,dcount-seq)
		if thcard:IsAbleToHand() then
			Duel.DisableShuffleCheck()
			Duel.BreakEffect()
			if Duel.SendtoHand(thcard,nil,REASON_EFFECT)>0 and aux.PLChk(tc,tp,LOCATION_HAND) then
				Duel.ConfirmCards(1-tp,thcard)
				Duel.ShuffleHand(tp)
			end
		end
		Duel.ShuffleDeck(tp)
		
	else
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			local c=e:GetHandler()
			if not c:IsRelateToChain() then return end
			local sc=Duel.GetOperatedGroup():GetFirst()
			if sc and sc:IsLocation(LOCATION_MZONE) and c:IsCanOverlay(tp) and not sc:IsImmuneToEffect(e) then
				Duel.Attach(c,sc)
			end
		end
	end
end