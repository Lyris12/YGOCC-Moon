--Alien' Sharks
function c16000871.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,4,c16000871.filter1,1)  
   --destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16000871,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c16000871.cost)
	e1:SetTarget(c16000871.target)
	e1:SetOperation(c16000871.operation)
	c:RegisterEffect(e1)
   --self destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16000871,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCondition(c16000871.descon)
	e2:SetTarget(c16000871.destg)
	e2:SetOperation(c16000871.desop)
	c:RegisterEffect(e2)
end



function c16000871.filter1(c,ec,tp)
	return c:IsRace(RACE_FISH) or c:IsAttribute(ATTRIBUTE_DARK)
end

function c16000871.cost(e,tp,eg,ep,ev,re,r,rp,chk)
		 if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
	e:GetHandler():RemoveEC(tp,4,REASON_COST)
end
function c16000871.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c16000871.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsOnField() and c16000871.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(c16000871.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c16000871.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c16000871.operation(e,tp,eg,ep,ev,re,r,rp)
   local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Destroy(g,REASON_EFFECT)
end


function c16000871.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttackTarget()==c and c:GetEC()==0
end
function c16000871.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker():IsRelateToBattle() end
  Duel.SetTargetCard(Duel.GetAttacker())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
		 Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
function c16000871.desop(e,tp,eg,ep,ev,re,r,rp)
	   local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and  tc:IsRelateToEffect(e) then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		 Duel.Destroy(tc,REASON_EFFECT)
	end
end