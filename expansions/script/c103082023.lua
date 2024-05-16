-- Abyss Actor - Tiny Stagehand for KPro
function c103082023.initial_effect(c)
	aux.AddSetNameMonsterList(c,0x20ec,0x10ec)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--Pendulum Effect
	--Pay 500 LP; Special Summon 1 "Abyss Actor" Monster from your hand.
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{103082023,1})
	e1:SetCost(c103082023.payLP)
	e1:SetTarget(c103082023.target)
	e1:SetOperation(c103082023.SPsummon)
	c:RegisterEffect(e1)

	--Monster Effect
	--Make 1 monster you control gain 500 ATK for each "Abyss Script" in your GY.

	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCountLimit(1)
	e2:SetTarget(c103082023.atkGAINtg) 
	e2:SetOperation(c103082023.opATK)
	c:RegisterEffect(e2)

	--If destroyed: Target cards that are banished or in the GYs equal to the number of different "Abyss Actors" you control and shuffle them into the deck.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK) 
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O) --Optional Effect
	e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET) --Cannot miss timing
	e3:SetCode(EVENT_DESTROYED) --If the card is destroyed
	e3:SetCountLimit(1,103082023)
	e3:SetTarget(c103082023.toDeck)
	e3:SetOperation(c103082023.ShuffleOp)
	c:RegisterEffect(e3)
end

function c103082023.payLP(e,tp,eg,ep,ev,re,r,rp,chk) --Sets LP Cost for Special Summon
	if chk == 0 then return Duel.CheckLPCost(tp, 500) end --if activated, checks if you can pay the cost
	Duel.PayLPCost(tp,500) --Pays the cost
end

function c103082023.target(e,tp,eg,ep,ev,re,r,rp,chk) --Determines which monster will be special summoned
	if chk==0 then return Duel.IsExistingMatchingCard(c103082023.filtro,tp,LOCATION_HAND,0,1,nil, e, tp) and --Checks if there's an "Abyss Actor" Monster that can be special summoned from your hand to your field
		Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end --Checks the quantity of Free Monster zones you control
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND) --Tells the game that it will perform a Special Summon from your hand
end

function c103082023.atkGAINtg(e,tp,eg,ep,ev,re,r,rp,chk) --Determines which monster will receive the ATK boost (doesn't target)
	if chk == 0 then return Duel.IsExistingMatchingCard(c103082023.atkGAINfilter,tp,LOCATION_GRAVE,0,1,nil) and --Checks that there is any "Abyss Scripts" cards in your GY
	Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0, 1, nil) end --Checks if there's a Face-up monster on your field
	Duel.SetOperationInfo(0, CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE) --Effect will change the atk/def of a monster we currently control during this chain
end

function c103082023.opATK(e,tp,eg,ep,ev,re,r,rp) --Resolves the ATK increase effect
	local SIGY = Duel.GetMatchingGroupCount(c103082023.atkGAINfilter,tp,LOCATION_GRAVE, 0,nil) --SIGY (Scripts in Graveyard) saves the quantity of
	--"Abyss Scripts" cards in your GY
	if SIGY == 0 then return end --if there's no Abyss Scripts at resolution, the effect does nothing
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP) --Tells the game that we'll increase ATK/DEF
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,1,1,nil) --Saves and chooses the Face-up monster that will get the ATK Boost
	Duel.HintSelection(g,true) --Confirms the monster to the opponent
	if #g>0 then --If there is one
		local e1=Effect.CreateEffect(e:GetHandler()) --Creates the ATK Boost to be applied
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(SIGY*500) --Gains ATK equal to the quantity of "Abyss Script" cards in your GY
		g:GetFirst():RegisterEffect(e1)
	end
end

function c103082023.SPsummon(e,tp,eg,ep,ev,re,r,rp) --Performs the Special Summon from Hand
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c103082023.filtro,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) --Special Summons the Selected Monster
	end
end

function c103082023.toDeck(e,tp,eg,ep,ev,re,r,rp,chk,chkc) --Determines the cards that will be Shuffled into the deck that are banished or in the GYs (Effect Targets)
	local AAs = Duel.GetMatchingGroup(c103082023.onFieldFilter,tp,LOCATION_MZONE,0,nil) --Saves the quantity of "Abyss Actor" Monsters on the field
	local dn = AAs:GetClassCount(Card.GetCode) --Checks which monsters have different names
	if chck then return chkc:IsLocation(LOCATION_REMOVED | LOCATION_GRAVE) and chck:IsAbleToDeck() end --Checks that there are Banished cards or in the GYs
	--That can be Shuffled into the deck.
	if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED | LOCATION_GRAVE, LOCATION_GRAVE | LOCATION_REMOVED,1, nil) and 
		Duel.IsExistingMatchingCard(c103082023.onFieldFilter,tp,LOCATION_MZONE,0,1,nil)end
	--Checks that there are any cards that can be shuffled into the deck that are banished or in the GYs
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK) --Tells the game that it will select cards to shuffle into the deck
	
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED | LOCATION_GRAVE, LOCATION_GRAVE | LOCATION_REMOVED,1,dn, nil) --Select the cards that will
	--be shuffled into the deck from among the Banished cards or in the GYs, up to the number of "Abyss Actor" monsters we control with different names
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,PLAYER_EITHER,LOCATION_REMOVED|LOCATION_GRAVE) --Tells the game that we will shuffle the cards into the deck
end

function c103082023.ShuffleOp(e,tp,eg,ep,ev,re,r,rp) --Performs the Deck Shuffling
	local g=Duel.GetTargetCards(e) --gets the cards that will be shuffled into the deck
	if #g>0 then --As long as they are more than 0
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) --the cards are shuffled by a card effect
	end
end

function c103082023.filtro(c,e,tp) --filters the cards that can be special summoned from the hand
	return c:IsSetCard(0x10ec) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	--It has to be an "Abyss Actor" Monster that can be special summoned to your field
end

function c103082023.atkGAINfilter(c) --Filters the cards that will be taken as reference for the multiplier of the ATK boost
	return c:IsSetCard(0x20ec)
end

function c103082023.onFieldFilter(c) --Filters the cards that will be taken as reference to select the cards to shuffle
	return c:IsSetCard(0X10ec)
	--It is an "Abyss Actor" monster that is face-up on the field
end