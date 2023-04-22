--Futurender Hyperdrive
--Render Futurminatore Iperdrive
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[Equip only to a Drive Monster.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	--[[3+: Cannot be destroyed by battle or card effects.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	e3x:SetRange(LOCATION_SZONE)
	e3x:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3x:SetCondition(s.efcon(3))
	e3x:SetTarget(s.eftg)
	e3x:SetLabelObject(e3)
	c:RegisterEffect(e3x)
	local e4x=e3x:Clone()
	e4x:SetLabelObject(e4)
	c:RegisterEffect(e4x)
	--[[5+: Can attack a number of times each Battle Phase up to the Energy of your Engaged monster, but all battle damage it inflicts to your opponent is halved.]]
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EXTRA_ATTACK)
	e5:SetValue(s.raval)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e6:SetValue(aux.ChangeBattleDamage(1,200))
	local e5x=e3x:Clone()
	e5x:SetCondition(s.efcon(5))
	e5x:SetLabelObject(e5)
	c:RegisterEffect(e5x)
	local e6x=e3x:Clone()
	e6x:SetCondition(s.efcon(5))
	e6x:SetLabelObject(e6)
	c:RegisterEffect(e6x)
	--[[1+: Once per turn, you can activate 1 Overdrive Effect of a Drive Monster without having to reduce its Energy to 0.]]
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCode(EFFECT_IGNORE_OVERDRIVE_COST)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(1,0)
	e7:OPT()
	e7:SetValue(1)
	local e7x=e3x:Clone()
	e7x:SetCondition(s.efcon(1))
	e7x:SetLabelObject(e7)
	c:RegisterEffect(e7x)
	--[[7+: Negate the effects of all face-up monsters on the field, except Drive Monsters.]]
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_DISABLE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e8:SetTarget(s.distg)
	local e8x=e3x:Clone()
	e8x:SetCondition(s.efcon(7))
	e8x:SetLabelObject(e8)
	c:RegisterEffect(e8x)
	--[[9+: If this card inflicts battle damage to your opponent, you win the Duel at the end of that turn's Battle Phase if this card is still face-up on the field]]
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCode(EVENT_BATTLE_DAMAGE)
	e9:SetCondition(s.wincon)
	e9:SetOperation(s.winop)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCountLimit(1)
	e10:SetCondition(s.wincon2)
	e10:SetOperation(s.winop2)
	c:RegisterEffect(e10)
	local e9x=e3x:Clone()
	e9x:SetCondition(s.efcon(9))
	e9x:SetLabelObject(e9)
	c:RegisterEffect(e9x)
	local e10x=e3x:Clone()
	e10x:SetCondition(s.efcon(9))
	e10x:SetLabelObject(e10)
	c:RegisterEffect(e10x)
end
function s.filter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_DRIVE)
end
function s.eqlimit(e,c)
	return c:IsType(TYPE_DRIVE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetCardOperationInfo(e:GetHandler(),CATEGORY_EQUIP)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

function s.cfilter(c)
	return c:NotOnFieldOrFaceup() and c:IsSetCard(ARCHE_HYPERDRIVE)
end
function s.efcon(ct)
	return	function(e)
				local g=Duel.GetMatchingGroup(s.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
				return g:GetClassCount(Card.GetCode)>=ct
			end
end
function s.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end

function s.raval(e,c)
	local en=Duel.GetEngagedCard(e:GetHandlerPlayer())
	if not en then return 0 end
	local ct=en:GetEnergy()
	return math.max(0,ct-1)
end

function s.distg(e,c)
	return not c:IsMonster(TYPE_DRIVE) and (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT)
end

function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,0,1)
	end
end

function s.wincon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(id)
end
function s.winop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:HasFlagEffect(id) then
		Duel.Win(tp,WIN_REASON_CUSTOM)
	end
end