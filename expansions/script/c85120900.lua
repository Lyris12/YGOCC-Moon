--[[
Spark of the Primordial Sun
Scintilla del Sole Primordiale
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MACRO_COSMOS,CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS,CARD_HELIOS_TRICE_MEGISTUS)
	--If you control "Macro Cosmos", you can Special Summon this card (from your hand).
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT(true)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--[[Once per turn: You can excavate the top 5 cards of your Deck, and if you do, add 1 "Helios - The Primordial Sun" or 1 card that mentions it from among them to your hand,
	and if you do that, banish the rest and this card. Otherwise, shuffle all excavated cards into the Deck.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_REMOVE|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e2)
	--[[If you control "Helios - The Primordial Sun" or "Helios Duo Megistus": You can shuffle this banished card into the Deck; add 1 "Helios Thrice Megistus" from your Deck to your hand,
	and if you do, draw 1 card.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORIES_SEARCH|CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_REMOVED)
	e3:HOPT()
	e3:SetFunctions(aux.LocationGroupCond(s.cfilter,LOCATION_ONFIELD,0,1),aux.ToDeckSelfCost,s.thtg,s.thop)
	c:RegisterEffect(e3)
end

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsCode(CARD_MACRO_COSMOS)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end

--E2
function s.deckchk(c,g)
	return c:IsAbleToHand() and g:FilterCount(Card.IsAbleToRemove,c)==#g-1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(tp,5)
	if chk==0 then
		if not c:IsAbleToRemove() or #g<5 then return false end
		return g:IsExists(s.deckchk,1,nil,g)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,c,5,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsCodeOrMentions(CARD_HELIOS_THE_PRIMORDIAL_SUN)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	if #g>0 then
		Duel.DisableShuffleCheck()
		local shuffle=true
		if g:IsExists(s.thfilter,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tc=g:FilterSelect(tp,s.thfilter,1,1,nil):GetFirst()
			if tc:IsAbleToHand() then
				if Duel.SearchAndCheck(tc,tp,nil,nil,REASON_EFFECT|REASON_EXCAVATE) then
					shuffle=false
					Duel.ShuffleHand(tp)
					g:RemoveCard(tc)
					local c=e:GetHandler()
					if c:IsRelateToChain() then
						g:AddCard(c)
					end
					local rg=g:Filter(Card.IsAbleToRemove,nil)
					if #rg>0 then
						g:Sub(rg)
						Duel.Remove(rg,POS_FACEUP,REASON_EFFECT|REASON_EXCAVATE)
					end
					if #g>0 then
						Duel.SendtoGrave(g,REASON_RULE)
					end
				end

			else
				Duel.SendtoGrave(tc,REASON_RULE)
			end
		end
		if shuffle then
			Duel.ShuffleDeck(tp)
		end
	end
end

--E3
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_HELIOS_THE_PRIMORDIAL_SUN,CARD_HELIOS_DUO_MEGISTUS)
end
function s.thfilter2(c)
	return c:IsCode(CARD_HELIOS_TRICE_MEGISTUS) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetDeckCount(tp)>1 and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g,tp) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end