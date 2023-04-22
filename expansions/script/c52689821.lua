--Drive Stick
--Levadicambio Drive
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[(Quick Effect): You can discard this card, then target 1 Drive Monster you control and declare a number from 1 to 6; apply 1 of these effects depending on the declared number.
	● 1 to 5: Assign the numbers from 1 to 5 to your Main Monster Zones, starting from the leftmost one and proceeding towards the rightmost one,
	and choose the zone the declared number was assigned to. If you chose an unoccupied zone, move the targeted monster to that zone, and if you do,
	add 1 Drive Monster from your Deck to your hand, whose original Energy is equal to the declared number, and if you do that, you can Engage it.
	● 6: Shuffle the targeted monster into the Deck, and if you do, add 1 Drive Monster with 6 or more original Energy from your Deck to your hand, and if you do, you can Engage it.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(aux.DiscardSelfCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	if not (c:IsFaceup() and c:IsMonster(TYPE_DRIVE)) then return false end
	if c:IsAbleToGrave() or (c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)) then return true end
	for i=0,4 do
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,1<<i)
		if ft>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,i+1) then
			return true
		end
	end
	return false
end
function s.thfilter(c,en)
	return c:IsMonster(TYPE_DRIVE) and c:IsAbleToHand() and ((not en and c:IsEnergyAbove(6)) or (en and c:IsEnergy(en)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	local n={}
	for i=0,5 do
		if i<5 then
			local check=false
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,1<<i)
			if ft>0 then
				check=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,i+1)
			elseif ft<=0 and Duel.IsExistingMatchingCard(Card.IsSequence,tp,LOCATION_MZONE,0,1,nil,i) then
				check=tc:IsAbleToGrave()
			end
			if check then
				table.insert(n,i+1)
			end
		else
			if tc:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) then
				table.insert(n,6)
			end
		end
	end
	if #n>0 then
		local opt=Duel.AnnounceNumber(tp,table.unpack(n))
		if opt<6 then
			e:SetCategory(CATEGORIES_SEARCH|CATEGORY_TOGRAVE)
		else
			e:SetCategory(CATEGORIES_SEARCH|CATEGORY_TODECK)
			Duel.SetCardOperationInfo(tc,CATEGORY_TODECK)
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		end
		e:SetLabel(opt-1)
	else
		e:SetCategory(0)
		e:SetLabel(-1)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt<0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not tc:IsControler(tp) then return end
	if opt<5 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,1<<opt)>0 then
			local prev_seq=tc:GetSequence()
			Duel.MoveSequence(tc,opt)
			local seq=tc:GetSequence()
			if seq==opt and prev_seq~=seq then
				local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,opt+1)
				if #g>0 then
					Duel.SearchAndEngage(g:GetFirst(),e,tp)
				end
			end
		elseif Duel.IsExistingMatchingCard(Card.IsSequence,tp,LOCATION_MZONE,0,1,nil,opt) then
			Duel.SendtoGrave(tc,REASON_EFFECT)
			Duel.LoseLP(tp,1000)
		end
	else
		if Duel.ShuffleIntoDeck(tc)>0 then
			local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #g>0 then
				Duel.SearchAndEngage(g:GetFirst(),e,tp)
			end
		end
	end
end