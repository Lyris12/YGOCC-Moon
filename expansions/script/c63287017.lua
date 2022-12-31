--Kybernetic Virus
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(cid.eqtg)
	e1:SetOperation(cid.eqop)
	c:RegisterEffect(e1)
	--undisablable summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(cid.effcon)
	c:RegisterEffect(e2)
	--immunity
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(cid.efilter)
	c:RegisterEffect(e3)
end
--EQUIP
--filters
function cid.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_MACHINE)
end
---------
function cid.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=e:GetHandler() and cid.eqfilter(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cid.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,cid.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function cid.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	if not Duel.Equip(tp,c,tc,false) then return end
	--unequip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	--Equip effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_MACHINE)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_EQUIP)
	e2x:SetCode(EFFECT_UPDATE_ATTACK)
	e2x:SetCondition(cid.controlcon)
	e2x:SetValue(1000)
	e2x:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2x)
	local e2y=Effect.CreateEffect(c)
	e2y:SetType(EFFECT_TYPE_EQUIP)
	e2y:SetCode(EFFECT_UPDATE_ATTACK)
	e2y:SetCondition(cid.controlcon2)
	e2y:SetValue(-500)
	e2y:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2y)
	local e2yy=e2y:Clone()
	e2yy:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2yy)
	--destroy sub
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(cid.reptg)
	e3:SetOperation(cid.repop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	--eqlimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(cid.eqlimit)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	e4:SetLabelObject(tc)
	c:RegisterEffect(e4)
end
--EQLIMIT
function cid.eqlimit(e,c)
	return c==e:GetLabelObject()
end
--UNEQUIP
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,true,false) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,1,tp,tp,true,false,POS_FACEUP)
end
--EQUIP EFFECTS
function cid.controlcon(e)
	local ph=Duel.GetCurrentPhase()
	return e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer()) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function cid.controlcon2(e)
	local ph=Duel.GetCurrentPhase()
	return not e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer()) and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
--DESTROY SUB
function cid.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler():GetEquipTarget()) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function cid.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,cid.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler():GetEquipTarget())
	if #g>0 then
		Duel.HintSelection(g)
		if not Duel.Equip(tp,e:GetHandler(),g:GetFirst(),false) then return end
		--eqlimit
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_EQUIP_LIMIT)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetValue(cid.eqlimit)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		e4:SetLabelObject(g:GetFirst())
		e:GetHandler():RegisterEffect(e4)
	end
end
--UNDISABLABLE SUMMON
function cid.effcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
--IMMUNITY
function cid.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER+TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end