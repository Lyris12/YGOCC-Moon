--Pharaohnic Ghast
local id,cod=23251020,c23251020
function cod.initial_effect(c)
	--Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(cod.pcod)
	e1:SetTarget(cod.ptg)
	e1:SetOperation(cod.pop)
	c:RegisterEffect(e1)
end
function cod.pcod(e,tp,eg,ep,ev,re,r,rp)
	return re and (re:GetHandler():IsSetCard(0xd3e) or re:GetHandler():IsCode(232510010))
end
function cod.ptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsPosition(POS_FACEUP) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),1-tp,POS_FACEDOWN_DEFENSE)
end
function cod.pop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
