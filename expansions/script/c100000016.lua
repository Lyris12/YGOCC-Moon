--Leilani the Flame Esprision
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsXyzType,TYPE_TUNER),3,2)
	--[[If this card is Special Summoned with no material attached to it: You can excavate cards from the top of your Deck until you excavate an "Esprision" card,
	then add that card to your hand, also shuffle the rest into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:HOPT()
	e1:SetCondition(s.exccon)
	e1:SetTarget(s.exctg)
	e1:SetOperation(s.excop)
	c:RegisterEffect(e1)
	--[[If a monster(s) with ATK higher than this card is Special Summoned to your opponent's field (except during the Damage Step):
	You can detach 1 material from this card; destroy that monster(s).]]
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_SPSUMMON_SUCCESS,s.egfilter,id,LOCATION_MZONE)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(aux.DetachSelfCost())
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--[[If this card is in your GY: You can send the top 3 cards of your Deck to the GY, and if you do, if an "Esprision" card was sent to the GY, Special Summon this card.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_DECKDES|CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:HOPT()
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.exccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanSendtoHand(tp) and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0xe50)
	end
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	local dcount=#g
	if dcount==0 then return end
	local sg=g:Filter(Card.IsSetCard,nil,0xe50)
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
end

function s.egfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(1-tp) and c:GetAttack()>e:GetHandler():GetAttack()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg end
	Duel.SetCardOperationInfo(eg,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(eg,REASON_EFFECT)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsPlayerCanDiscardDeck(tp,3) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	if c:IsLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_DECKDES|CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_DECKDES|CATEGORY_SPECIAL_SUMMON)
	end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.chkfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0xe50)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 or Duel.DiscardDeck(tp,3,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local g=Duel.GetOperatedGroup()
	if g:IsExists(s.chkfilter,1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end