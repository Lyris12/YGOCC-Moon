function c160003541.initial_effect(c)
	   aux.AddOrigEvoluteType(c)
  aux.AddEvoluteProc(c,nil,7,c160003541.filter1,2)
	c:EnableReviveLimit() 

		--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,160003541)
	e1:SetCondition(c160003541.descon)
	e1:SetCost(c160003541.discost)
	e1:SetTarget(c160003541.destg)
	e1:SetOperation(c160003541.desop)
	c:RegisterEffect(e1)
	--atk change
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(160003541,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1)
	e3:SetCondition(c160003541.atkcon)
	e3:SetTarget(c160003541.atktg)
	e3:SetOperation(c160003541.atkop)
	c:RegisterEffect(e3)
		--damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(160003541,0))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	 e4:SetCountLimit(1,160003542)
	e4:SetCondition(c160003541.damcon)
	e4:SetTarget(c160003541.damtg)
	e4:SetOperation(c160003541.damop)
	c:RegisterEffect(e4) 
end
function c160003541.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) or c:IsRace(RACE_PLANT) 
end

function c160003541.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle()  and bc:IsType(TYPE_MONSTER)
end
function c160003541.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	local dam=bc:GetTextAttack()
	if chk==0 then return dam>0 end
	Duel.SetTargetCard(bc)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function c160003541.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetTextAttack()
		if dam<0 then dam=0 end
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
function c160003541.filter1(c)
	return bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)~=0  and c:IsAbleToRemove()
end
function c160003541.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+388 and c:GetMaterial():IsExists(c160003541.pmfilter,1,nil)
end
function c160003541.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,4,REASON_COST) end
	e:GetHandler():RemoveEC(tp,4,REASON_COST)
end
function c160003541.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
end
function c160003541.pmfilter(c)
	return c:IsType(TYPE_RITUAL)
end
function c160003541.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c160003541.filter1,tp,0,LOCATION_ONFIELD,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function c160003541.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c160003541.filter1,tp,0,LOCATION_ONFIELD,2,2,nil)
	if g:GetCount()>0 then 
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function c160003541.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:GetCode()~=160003541
end
function c160003541.con(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(c160003541.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

function c160003541.discost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
		e:GetHandler():RemoveEC(tp,3,REASON_COST)
end

function c160003541.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsFaceup() and tc:GetAttack()>0 and tc:IsSummonType(SUMMON_TYPE_SPECIAL) 
end
function c160003541.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
function c160003541.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local atk=tc:GetAttack()
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(math.ceil(atk/2))
		c:RegisterEffect(e3)
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_SET_ATTACK_FINAL)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e4:SetValue(math.ceil(atk/2))
			tc:RegisterEffect(e4)
		end
	end
end
