--Kitseki Lunasa
--Script by XGlitchy30
function c88523884.initial_effect(c)
	--deck destruction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88523884,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,88523884)
	e1:SetTarget(c88523884.decktg)
	e1:SetOperation(c88523884.deckop)
	c:RegisterEffect(e1)
end
--filters
function c88523884.namefilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x215a)
end
--deck destruction
function c88523884.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function c88523884.deckop(e,tp,eg,ep,ev,re,r,rp)
	--name check
	local g=Duel.GetMatchingGroup(c88523884.namefilter,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()<=0 then return end
	local av=g:GetClassCount(Card.GetCode)
	----------
	local c=e:GetHandler()
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	if ct>av then ct=av end
	local t={}
	for i=1,ct do t[i]=i end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(88523884,1))
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.DiscardDeck(tp,ac,REASON_EFFECT)
	local op=Duel.GetOperatedGroup()
	Duel.BreakEffect()
	Duel.DiscardDeck(1-tp,op:GetCount(),REASON_EFFECT)
end