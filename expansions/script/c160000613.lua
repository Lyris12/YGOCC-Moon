--Yokaidy Oni Gyaru
function c160000613.initial_effect(c)

	  --special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c160000613.spcon)
	c:RegisterEffect(e1) 
   --atk up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41209827,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,160000613)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c160000613.acop)
	c:RegisterEffect(e2)
 --search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(160000613,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,160000614)
	e3:SetTarget(c160000613.target)
	e3:SetOperation(c160000613.operation)
	c:RegisterEffect(e3)
 
end
function c160000613.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
function c160000613.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and not Duel.IsExistingMatchingCard(c160000613.spfilter,tp,0,LOCATION_MZONE,1,nil)
end
function c160000613.kafilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_DARK)
end
function c160000613.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c160000613.kafilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1241,1)
		 local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetCondition(c160000613.discon)
		e1:SetValue(-1)
		tc:RegisterEffect(e1)
			local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RANK)
	tc:RegisterEffect(e2)
		 --atk down
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetCondition(c160000613.discon)
		e3:SetReset(RESET_EVENT+0x1fe0000)
		e3:SetValue(ATTRIBUTE_DARK)
		tc:RegisterEffect(e3)
		--atk down
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetCondition(c160000613.discon)
		e4:SetValue(RACE_FIEND)
		e4:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e4)
		tc=g:GetNext()
	end
end

function c160000613.discon(e)
	return e:GetHandler():GetCounter(0x1241)>0
end

function c160000613.target(e,tp,eg,ep,ev,re,r,rp,chk)
	  if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE and c160000613.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c160000613.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c160000613.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c160000613.filter(c)
	return c:IsSetCard(0xc911) and c:IsType(TYPE_MONSTER) and not c:IsCode(160000613) and c:IsAbleToHand()
end
function c160000613.operation(e,tp,eg,ep,ev,re,r,rp)
   local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end