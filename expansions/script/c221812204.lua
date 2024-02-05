--[[
Viravolve Demon
Viravolve Demone
Original Script by: Lyris
Rescripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.RegisterMergedDelayedEventGlitchy(c,id,EVENT_SPSUMMON_SUCCESS,s.filter,id)
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetCategory(CATEGORY_EQUIP)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_CUSTOM+id)
	e0:SetRange(LOCATION_HAND)
	e0:SetTarget(s.eqtg)
	e0:SetOperation(s.eqop)
	c:RegisterEffect(e0)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(aux.TurnPlayerCond(0))
	e3:SetCost(aux.InfoCost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	e3x:SetRange(LOCATION_SZONE)
	e3x:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3x:SetTarget(s.granttg)
	e3x:SetLabelObject(e3)
	c:RegisterEffect(e3x)
	--replace detach cost
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.rcon)
	e4:SetOperation(s.rop)
	c:RegisterEffect(e4)
	local e4x=e3x:Clone()
	e4x:SetLabelObject(e4)
	c:RegisterEffect(e4x)
	--damage
	aux.AddViravolveDamageEffect(c,id)
end
--E0
function s.filter(c,_,tp,eg)
	return #eg==1 and c:IsFaceup() and c:IsSetCard(ARCHE_VIRAVOLVE) and c:IsType(TYPE_XYZ) and c:IsRace(RACE_CYBERSE) and c:IsRank(1) and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #eg>0 and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
	end
	local tc=eg:GetFirst()
	if #eg>1 then
		Duel.HintMessage(tp,HINTMSG_OPERATECARD)
		local g=eg:Select(tp,1,1,nil)
		Duel.HintSelection(g)
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetCardOperationInfo(c,CATEGORY_EQUIP)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToChain() then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	Duel.EquipToOtherCardAndRegisterLimit(e,tp,c,tc,true)
end

--E3
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(200)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

--E3X
function s.granttg(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return ec~=nil and c==ec and c:IsSetCard(ARCHE_VIRAVOLVE)
end

--E4
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id) and c:IsAbleToGrave()
end 
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (type(aux.RemoveOverlayCard)=="table" and aux.RemoveOverlayCard[c:GetControler()+1]==1) or (aux.GetValueType(aux.RemoveOverlayCard)=="Card" and aux.RemoveOverlayCard==c) then
		return ep==e:GetHandlerPlayer() and c:GetOverlayCount()>=ev-1 and c:GetEquipGroup():IsExists(s.cfilter,1,nil)
	end
	return false
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintMessage(tp,HINTMSG_TOGRAVE)
	local g=c:GetEquipGroup():FilterSelect(tp,s.cfilter,1,1,nil)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.HintSelection(g)
	return Duel.SendtoGrave(g,REASON_EFFECT)
end