--Rose the Forest Esprision
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--You can reveal this card in your hand; toss a coin and if the result is heads, Special Summon this card, otherwise discard 1 card.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN|CATEGORY_SPECIAL_SUMMON|CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(aux.RevealSelfCost())
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--During your Main Phase: You can roll a six-sided die and apply the result.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DICE|CATEGORIES_SEARCH|CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetTarget(s.dctg)
	e2:SetOperation(s.dcop)
	c:RegisterEffect(e2)
end
s.toss_coin=true
s.toss_dice=true

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local heads = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		local tails = Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT)
		return heads or tails
	end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local coin=Duel.TossCoin(tp,1)
	if coin==COIN_HEADS and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
		
	elseif coin==COIN_TAILS then
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	end
end

function s.thfilter(c,typ)
	return c:IsType(typ) and c:IsSetCard(0xe50)
end
function s.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local not_four = Duel.IsPlayerCanSendtoHand(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,TYPE_ST)
		local four = Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,0,LOCATION_HAND,1,nil,REASON_EFFECT)
		return four or not_four
	end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d~=4 then
		local options={}
		local types, available_types = {TYPE_SPELL,TYPE_TRAP}, {}
		local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
		local dcount=#g
		if dcount==0 then return end
		for i,typ in ipairs(types) do
			if g:IsExists(s.thfilter,1,nil,typ) then
				table.insert(options,i+70)
				table.insert(available_types,typ)
			end
		end
		if #options==0 then return end
		local op=Duel.SelectOption(tp,table.unpack(options))+1
		local typ=available_types[op]
		local sg=g:Filter(s.thfilter,nil,typ)
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
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if #g==0 then return end
		local sg=g:RandomSelect(tp,1)
		if #sg>0 then
			Duel.SendtoGrave(sg,REASON_EFFECT|REASON_DISCARD)
		end
	end
end