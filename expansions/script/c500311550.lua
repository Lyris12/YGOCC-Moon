--Buttergal of Fiber VINE
function c500311550.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,4,c500311550.filter1,2,2)
	c:EnableReviveLimit() 
  --cannot be target/battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c500311550.con)
	e1:SetTarget(c500311550.tgtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
  e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetValue(1)
	c:RegisterEffect(e2)

		 --tohand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(500311550,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,0x1e0)
	e0:SetCountLimit(1)
	--e3:SetCondition(c500311550.condition)
	e0:SetCost(c500311550.cost)
	e0:SetTarget(c500311550.target)
	e0:SetOperation(c500311550.operation)
	c:RegisterEffect(e0)
   
end
function c500311550.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) or c:IsRace(RACE_PLANT) 
end
function c500311550.con(e,tp,eg,ep,ev,re,r,rp)
	return  e:GetHandler():GetEC()==4
end
function c500311550.tgtg(e,c)
	return  c:IsType(TYPE_RITUAL) or c:IsType(TYPE_EVOLUTE)
end
function c500311550.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
		 if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
	e:GetHandler():RemoveEC(tp,4,REASON_COST)
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
function c500311550.tgfilter(c)
	 return c:IsSetCard(0x185a) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(c500311550.thfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function c500311550.thfilter(c,code)
	return  c:IsSetCard(0x185a) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and not c:IsForbidden() and c:IsAbleToHand()
end
function c500311550.target(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chk==0 then return Duel.IsExistingMatchingCard(c500311550.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c500311550.operation(e,tp,eg,ep,ev,re,r,rp)
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c500311550.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,c500311550.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		if sg:GetCount()>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
