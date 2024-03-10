--created by Walrus, coded by XGlitchy30
--Voidictator Rune - Soul of the Guardian
local s,id,o=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	c:SetUniqueOnField(1,0,id)
	aux.AddCodeList(c,CARD_VOIDICTATOR_DEMON_GUARDIAN_OF_CORVUS)
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
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.cfilter,id,LOCATION_SZONE,nil,LOCATION_SZONE,nil,nil,true)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3)
	e3:SetFunctions(nil,nil,s.eftg,s.efop)
	local ge=Effect.CreateEffect(c)
	ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_GRANT)
	ge:SetRange(LOCATION_SZONE)
	ge:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	ge:SetLabelObject(e3)
	ge:SetCondition(s.grantcon)
	ge:SetTarget(s.grantfilter)
	c:RegisterEffect(ge)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(1)
	e4:SetCondition(s.actcon)
	local ge2=ge:Clone()
	ge2:SetLabelObject(e4)
	c:RegisterEffect(ge2)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetValue(s.atkval)
	local ge3=ge:Clone()
	ge3:SetLabelObject(e5)
	c:RegisterEffect(ge3)
end
function s.filter(c)
	if not c:IsFaceup() then return false end
	return c:IsCode(CARD_VOIDICTATOR_DEMON_GUARDIAN_OF_CORVUS)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end
function s.eqlimit(e,c)
	return c:IsCode(CARD_VOIDICTATOR_DEMON_GUARDIAN_OF_CORVUS)
end
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsSummonPlayer(1-tp)
end
function s.checkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and not c:IsForbidden()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(s.checkfilter,nil)
	if not c:IsRelateToChain() or c:IsFacedown() or #g<=0 then return end
	local tc=g:GetFirst()
	if #g>1 then
		Duel.HintMessage(tp,HINTMSG_SELECT)
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		tc=sg:GetFirst()
	else
		Duel.HintSelection(Group.FromCards(tc))
	end
	if tc then
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
	end
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.atkcon(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and bc and bc:IsControler(1-e:GetHandlerPlayer())
end
function s.atkval(e,c)
	local bc=e:GetHandler():GetBattleTarget()
	local atk,def=bc:GetAttack(),bc:GetDefense()
	if not bc:HasAttack() then atk=0 end
	if not bc:HasDefense() then def=0 end
	return math.max(atk,def)
end
function s.grantcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and s.filter(ec)
end
function s.grantfilter(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and c==ec and s.filter(ec)
end
