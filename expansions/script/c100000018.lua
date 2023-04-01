--Azalea the Lightning Esprision
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsXyzType,TYPE_TUNER),3,2)
	--[[If this card is Special Summoned with no material attached to it: You can target 1 card your opponent controls; shuffle it into the Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:HOPT()
	e1:SetCondition(s.exccon)
	e1:SetTarget(s.exctg)
	e1:SetOperation(s.excop)
	c:RegisterEffect(e1)
	--[[When your opponent Special Summons a monster(s) from the Extra Deck: You can detach 1 material from this card;
	add 1 "Esprision" Spell/Trap from your Deck to your hand.]]
	local filter=aux.STFilter(Card.IsSetCard,0xe50)
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(s.thcost)
	e2:SetCost(aux.DetachSelfCost())
	e2:SetTarget(aux.SearchTarget(filter))
	e2:SetOperation(aux.SearchOperation(filter))
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
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

function s.cfilter(c,tp)
	return c:GetSummonPlayer()==1-tp and c:GetSummonLocation()==LOCATION_EXTRA
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
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