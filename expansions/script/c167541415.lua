--Primalgeddon, Against their Machines
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--ACTIVATE
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function cid.costfilter(c)
	return c:IsSetCard(0x487) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
function cid.filter(c)
	return (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and cid.filter(chkc) end
	if chk==0 then
		if e:GetLabel()==1 then
			e:SetLabel(0)
			return Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_HAND,0,1,nil)
				and Duel.IsExistingTarget(cid.filter,tp,0,LOCATION_ONFIELD,1,e:GetHandler())
		else return false end
	end
	e:SetLabel(0)
	local rt=Duel.GetTargetCount(cid.filter,tp,0,LOCATION_ONFIELD,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local cg=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_HAND,0,1,rt,nil)
	local ct=cg:GetCount()
	if ct>0 then
		Duel.ConfirmCards(1-tp,cg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,cid.filter,tp,0,LOCATION_ONFIELD,ct,ct,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	Duel.Destroy(sg,REASON_EFFECT)
end
