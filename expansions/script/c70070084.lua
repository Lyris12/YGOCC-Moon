--Muscwole IronSoul
local cid,id=GetID()
function cid.initial_effect(c)
	--BigBang summon
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,cid.sfilter,1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(cid.atk(4700))
	e2:SetTarget(cid.indestg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cid.atk(4700))
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--banish
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_START)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(cid.atkcon1(5400))
	e6:SetTarget(cid.distg)
	e6:SetOperation(cid.disop)
	c:RegisterEffect(e6)
	--attack all
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_ATTACK_ALL)
	e9:SetCondition(cid.atk(6100))
	e9:SetValue(1)
	c:RegisterEffect(e9)
	--cannot be target
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(cid.efilter)
	c:RegisterEffect(e7)
end
function cid.atk(val)
	return function(e)
		return e:GetHandler():IsAttackAbove(val)
	end
end
function cid.efilter(e,re,rp)
	return re:GetHandler():IsType(TYPE_EQUIP) and not re:GetHandler():IsSetCard(0x777)
end
function cid.sfilter(c)
	return c:IsSetCard(0x777) and aux.FilterEqualFunction(Card.GetVibe,1)
end
function cid.indestg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
function cid.atkcon1(val)
	return function(e)
		local c=e:GetHandler():GetBattleTarget()
		return c and e:GetHandler():IsAttackAbove(val)
	end
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttackTarget()
	if tc:IsControler(tp) then tc=Duel.GetAttacker() end
	local fid=tc:GetFieldID()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1,fid)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(cid.retcon)
	e1:SetOperation(cid.retop)
	Duel.RegisterEffect(e1,tp)
end
function cid.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetLabelObject():GetFlagEffectLabel(id)==e:GetLabel()) then
		e:Reset()
		return false
	else return true end
end
function cid.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
