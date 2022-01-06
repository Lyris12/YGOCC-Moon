--Naval Gears - Z46
local cid,id=GetID()
function cid.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,cid.lfilter,1,1)
	c:EnableReviveLimit()
		--set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65330383,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.spcon)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	  -- Negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88890001,2))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(cid.negcon)
	e2:SetCost(cid.negcost)
	e2:SetTarget(cid.negtg)
	e2:SetOperation(cid.negop)
	c:RegisterEffect(e2)
end
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cid.lfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x700) --and not c:IsCode(id)
end
function cid.ngfilter(c,e,sp)
	return c:IsSetCard(0x700) and c:GetOriginalType(TYPE_MONSTER)
end
function cid.thfilter(c)
	return c:IsSetCard(0x700) and  c:IsAbleToHand()
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
	   local e1=Effect.CreateEffect(e:GetHandler())
	   e1:SetCode(EFFECT_CHANGE_TYPE)
	   e1:SetType(EFFECT_TYPE_SINGLE)
	   e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	   e1:SetReset(RESET_EVENT+0x1fc0000)
	   e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
	   c:RegisterEffect(e1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	end
end
-- Negate
function cid.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(cid.ngfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
function cid.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function cid.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	end
function cid.negop(e,tp,eg,ep,ev,re,r,rp)
if chk==0 then return  end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if  Duel.NegateEffect(ev)  and rc:IsRelateToEffect(re) then
	rc:CancelToGrave()
		local option
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0  then option=0 end
		if Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then option=1 end
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0 then
			option=Duel.SelectOption(tp,aux.Stringid(4777,5),aux.Stringid(4777,6))
		end
		if option==0 then
			Duel.MoveToField(rc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fc0000)
	e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
	rc:RegisterEffect(e1)   

			end
		 if option==1 then
			Duel.MoveToField(rc,1-tp,1-tp,LOCATION_SZONE,POS_FACEUP,true)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fc0000)
	e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
	rc:RegisterEffect(e1)   
		
		
		
		end
	end
end

