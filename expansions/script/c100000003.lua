--Iris the Frost Esprision
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--If this card is added from your Deck to your hand, except by drawing it: You can Special Summon this card.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--During your opponent's turn (Quick Effect): You can roll a six-sided die and apply the result. 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DICE|CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetTarget(s.dctg)
	e2:SetOperation(s.dcop)
	c:RegisterEffect(e2)
end
s.toss_dice=true

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousLocation()&LOCATION_DECK==LOCATION_DECK and c:GetPreviousControler()==tp and not c:IsReason(REASON_DRAW)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToChain() then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(0xe50) and not c:IsCode(id)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xe50) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local not_four = Duel.IsPlayerCanSendtoHand(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		local four = Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		return not_four or four
	end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d~=4 then
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
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end