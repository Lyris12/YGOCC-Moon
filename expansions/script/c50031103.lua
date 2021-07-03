--Romana, Princess of Rose VINE
function c50031103.initial_effect(c)
	aux.AddOrigEvoluteType(c)
   aux.AddEvoluteProc(c,nil,4,c50031103.filter2,2,2,function(ec,tp,g) return g:FilterCount(c50031103.filter1,nil)==1 end)
	c:EnableReviveLimit()
local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50031103,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
   -- e1:SetCountLimit(1,50031103)
	e1:SetCondition(c50031103.condition)
	e1:SetTarget(c50031103.target)
	e1:SetOperation(c50031103.operation)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50031103,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c50031103.spcost)
	--e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e2:SetOperation(c50031103.spop)
	c:RegisterEffect(e2)
end
function c50031103.filter1(c,ec,tp)
	return c:IsType(TYPE_NORMAL)
end
function c50031103.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) or c:IsAttribute(ATTRIBUTE_FIRE) 
end
function c50031103.condition(e,tp,eg,ep,ev,re,r,rp)
	return  e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388 and e:GetHandler():IsLinkState()
end
function c50031103.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(50031103,0))
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	Duel.SetChainLimit(c50031103.limit(g:GetFirst()))
end
function c50031103.limit(c)
	return  function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
function c50031103.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if  c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
	  
		c:CreateRelation(tc,RESET_EVENT+0x5020000)
		tc:CreateRelation(c,RESET_EVENT+0x1fe0000)
		--local e1=Effect.CreateEffect(c)
		--e1:SetType(EFFECT_TYPE_SINGLE)
		--e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		--e1:SetCode(EFFECT_CANNOT_TRIGGER)
		--e1:SetReset(RESET_EVENT+0x1fe0000)
		--e1:SetCondition(c50031103.rcon)
		--e1:SetValue(1)
		--tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e3)
end
end
function c50031103.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsSummonable(true,nil)
end
function c50031103.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
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
  --  e1:SetTarget(c50031103.splimit)
   -- Duel.RegisterEffect(e1,tp)
end
function c50031103.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c.evolute and c~=e:GetLabelObject()
end

function c50031103.spop(e,tp,eg,ep,ev,re,r,rp)
	 local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c50031103.xxxfilter)
	e1:SetValue(3)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c50031103.xxxfilter(e,c)
	return c:IsType(TYPE_NORMAL)
end

