--[[
Stalwart Blade of Truesilver
Robusta Lama di Argentovero
Card Author: LeonDuvall
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id-1)
	c:SetUniqueOnField(1,0,id)
	--Activation
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	--The equipped monster gains 500 ATK/DEF.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	e3:UpdateDefenseClone(c)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_EQUIP)
	e3x:SetCode(EFFECT_ADD_TYPE)
	e3x:SetCondition(s.typecon)
	e3x:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e3x)
	--[[If the equipped monster would be destroyed by battle or card effect, you can destroy this card instead.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP|EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(s.replacetg)
	e4:SetValue(s.repval)
	e4:SetOperation(s.replaceop)
	c:RegisterEffect(e4)
	--[[If this card is equipped to "Lord of the Silver Tower", the equipped monster gains this effect.
	● Once per turn: You can send 1 Attack Position monster your opponent controls to the GY, then destroy 1 Spell you control.]]
	local e5=Effect.CreateEffect(c)
	e5:Desc(1)
	e5:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:OPT()
	e5:SetCost(aux.InfoCost)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(s.eftg)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
--E1
function s.filter(c,ec)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(5) and ec:CheckEquipTarget(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:CheckUniqueOnField(tp,LOCATION_SZONE) and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:CheckUniqueOnField(tp,LOCATION_SZONE) and tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

--E2
function s.eqlimit(e,c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(5)
end

--E3X
function s.typecon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetOriginalType()&TYPE_EFFECT==0 and c:IsCode(id-1)
end

--E4
function s.replacetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec and ec:IsReason(REASON_EFFECT|REASON_BATTLE) and not ec:IsReason(REASON_REPLACE) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else
		return false
	end
end
function s.repval(e,c)
	local ec=c:GetEquipTarget()
	return ec and c==ec and ec:IsReason(REASON_EFFECT|REASON_BATTLE) and not ec:IsReason(REASON_REPLACE)
end
function s.replaceop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	c:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(c,REASON_EFFECT|REASON_REPLACE)
end

--E5
function s.tgfilter(c)
	return c:IsPosition(POS_ATTACK) and c:IsAbleToGrave()
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSpell()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.Group(s.tgfilter,tp,0,LOCATION_MZONE,nil)
	local g2=Duel.Group(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		return #g1>0 and #g2>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #tg>0 then
		Duel.HintSelection(tg)
		local tc=tg:GetFirst()
		if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			local dg=Duel.Select(HINTMSG_DESTROY,false,tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
			if #dg>0 then
				Duel.HintSelection(dg)
				if dg:GetFirst():IsDestructable(e) then
					Duel.BreakEffect()
				end
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end

--E6
function s.eftg(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec==c and c:IsCode(id-1)
end