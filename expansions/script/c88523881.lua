--Kitseki Dousin
--Script by XGlitchy30
function c88523881.initial_effect(c)
	--spsummon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,88523881)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c88523881.spcon)
	c:RegisterEffect(e1)
	--deck destruction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88523881,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88513881)
	e2:SetCondition(c88523881.deckcon)
	e2:SetTarget(c88523881.decktg)
	e2:SetOperation(c88523881.deckop)
	c:RegisterEffect(e2)
end
--filters
function c88523881.spcheck(c)
	return c:IsFaceup() and c:IsSetCard(0x215a) and c:GetCode()~=88523881
end
--spsummon procedure
function c88523881.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(c88523881.spcheck,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
--deck destruction
function c88523881.deckcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
		and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)<5
end
function c88523881.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)<5 end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
function c88523881.deckop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=5 then return end
	Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
end