--Ingranaggio CPU: Orgoglio dell'Oracolo
--Scripted by: XGlitchy30
local s,id=GetID()

s.original_property={}
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local p1,p2=e1:GetProperty()
	s.original_property[e1]={p1,p2}
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetProperty(s.original_property[e][1],s.original_property[e][2])
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	Duel.PayLPCost(tp,2000)
end
function s.filter1(c,e,tp)
	return c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) and not c:IsPublic() or c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsCanBeEffectTarget(e))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,{c:GetCode()})
end
function s.filter2(c,codes)
	return c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(table.unpack(codes))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc and e:GetLabel()~=1 then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetFirst():IsLocation(LOCATION_HAND) then
		e:SetProperty(0)
		e:SetLabel(1)
		Duel.ConfirmCards(1-tp,g)
	else
		e:SetLabel(0)
	end
	Duel.SetTargetCard(g:GetFirst())
	g:GetFirst():CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,{tc:GetCode()})
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end