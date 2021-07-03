--9arsa Greenie fly of Rose VINE
function c50031569.initial_effect(c)
		aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,6,c50031569.filter2,2,2,function(ec,tp,g) return g:FilterCount(c50031569.filter1,nil)==1 end)
	c:EnableReviveLimit()
   --to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50031569,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)   
	e1:SetCost(c50031569.thcost)
	e1:SetTarget(c50031569.thtg)
	e1:SetOperation(c50031569.thop)
	c:RegisterEffect(e1)	
	--Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(50031569,2))
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCategory(CATEGORY_SUMMON)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c50031569.sumcon)
	e5:SetTarget(c50031569.sumtg)
	e5:SetOperation(c50031569.sumop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EVENT_TO_DECK)
	c:RegisterEffect(e7)	
	   --Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c50031569.checkop)
	c:RegisterEffect(e2)
end

function c50031569.checku(sg,ec,tp)
return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function c50031569.filter1(c,ec,tp)
	return c:IsType(TYPE_NORMAL)
end
function c50031569.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) or  c:IsAttribute(ATTRIBUTE_FIRE) 
end
function c50031569.thfilter(c)
	return  c:IsAbleToRemove()
end
   function c50031569.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	 e:GetHandler():RemoveEC(tp,3,REASON_COST)
	--local e1=Effect.CreateEffect(c)
  --  e1:SetType(EFFECT_TYPE_FIELD)
   -- e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
   -- e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
  --  e1:SetReset(RESET_PHASE+PHASE_END)
  --  e1:SetLabelObject(c)
  --  e1:SetTargetRange(1,0)
  --  e1:SetTarget(c50031569.splimit)
   -- Duel.RegisterEffect(e1,tp)
end
function c50031569.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ct=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE):FilterCount(function(c,e) return c:IsType(TYPE_LINK) and c:GetLinkedGroup():IsContains(e:GetHandler()) end,nil,e)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and c50031569.thfilter(chkc) end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c50031569.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,c50031569.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	--c:RegisterFlagEffect(0,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(50031569,2))
end
function c50031569.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function c50031569.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetEC()>0 then
		c:RegisterFlagEffect(50031569,RESET_EVENT+0x17a0000,0,0)
	end
end
function c50031569.checkop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
	return c:GetFlagEffect(50031569)>0
end
function c50031569.sumcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and  c:GetFlagEffect(50031569)>0
end
function c50031569.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsSummonable(true,nil)
end
function c50031569.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c50031569.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c50031569.sumop(e,tp,eg,ep,ev,re,r,rp) 
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c50031569.filter,tp,LOCATION_HAND,0,1,1,nil)
	local sg=g:GetFirst()
	if sg then
		Duel.Summon(tp,sg,true,nil) 
	local sg=g:GetNext()
	end
end