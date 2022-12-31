--Tortraveller - Tetsudominus
function c10110009.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,c10110009.ffilter,2,63,true)
	--summon success
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c10110009.matcheck)
	c:RegisterEffect(e2)
end
function c10110009.ffilter(c,fc)
	return c:IsFusionSetCard(0x4a5)
end
function c10110009.matcheck(e,c)
	local ct=c:GetMaterial():GetCount()
	if ct>0 then
		local ae=Effect.CreateEffect(c)
		ae:SetType(EFFECT_TYPE_SINGLE)
		ae:SetCode(EFFECT_SET_BASE_DEFENSE)
		ae:SetValue(ct*800)
		ae:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(ae)
	end
	if ct>=2 then
		--cannot be target
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(1)
		c:RegisterEffect(e2)
		--defense attack
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DEFENSE_ATTACK)
		e3:SetValue(1)
		c:RegisterEffect(e3)
	end
	if ct>=4 then
		--draw
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(10110009,1))
		e4:SetCategory(CATEGORY_DRAW)
		e4:SetType(EFFECT_TYPE_IGNITION)
		e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCountLimit(1)
		e4:SetCost(c10110009.drcost)
		e4:SetTarget(c10110009.drtg)
		e4:SetOperation(c10110009.drop)
		c:RegisterEffect(e4)
	end
	if ct>=6 then
		--cannot be destroyed
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e5:SetRange(LOCATION_MZONE)
		e5:SetValue(1)
		c:RegisterEffect(e5)
		--double
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e6:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
		c:RegisterEffect(e6)
	end
end
function c10110009.cfilter(c)
	return c:IsRace(RACE_AQUA) and c:IsAbleToDeckAsCost()
end
function c10110009.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c10110009.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c10110009.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function c10110009.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c10110009.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

