--Raphaela, of Virtue
function c9945350.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9945350,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,9945350)
	e1:SetCost(c9945350.descost)
	e1:SetTarget(c9945350.destg)
	e1:SetOperation(c9945350.desop)
	c:RegisterEffect(e1)
	--effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9945350,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,9945351)
	e2:SetTarget(c9945350.efftg)
	e2:SetOperation(c9945350.effop)
	c:RegisterEffect(e2)
end
function c9945350.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0x204F) end
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0x204F)
	Duel.Release(g,REASON_COST)
end
function c9945350.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsDestructable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c9945350.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,nil,REASON_EFFECT)
	end
end
function c9945350.lvfilter(c)
	return c:IsSetCard(0x204F)
end
function c9945350.cfilter2(c)
	return c:IsSetCard(0x204F) and c:IsLevelAbove(2)
end
function c9945350.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
		and not Duel.IsExistingMatchingCard(c9945350.cfilter,tp,LOCATION_SZONE,0,1,e:GetHandler())
end
function c9945350.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) 
		and Duel.IsExistingMatchingCard(c9945350.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local opt=0
	if not Duel.IsExistingMatchingCard(c9945350.cfilter2,tp,LOCATION_MZONE,0,1,nil) then
		opt=Duel.SelectOption(tp,aux.Stringid(9945350,2))
	else
		opt=Duel.SelectOption(tp,aux.Stringid(9945350,2),aux.Stringid(9945350,3))
	end
	e:SetLabel(opt)
end
function c9945350.effop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c9945350.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		if e:GetLabel()==0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		else
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_LEVEL)
			e2:SetValue(-1)
			e2:SetReset(RESET_EVENT+0x1fe0000)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end