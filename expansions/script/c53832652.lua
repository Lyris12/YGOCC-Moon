--Addominallenatore
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:Ignition(0,CATEGORY_EQUIP,EFFECT_FLAG_CARD_TARGET,LOCATION_MZONE+LOCATION_HAND,{1,0},nil,nil,s.eqtg,s.eqop)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.poscon)
	e2:SetOperation(s.posop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.mattg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--
	SCRIPT_AS_EQUIP=true
	c:UpdateDEF(2600,false)
	SCRIPT_AS_EQUIP=false
	--
	c:PositionFieldTrigger(nil,false,2,CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_ATKCHANGE,EFFECT_FLAG_CARD_TARGET,LOCATION_SZONE,nil,s.condition,nil,s.target,s.operation)
end
function s.unionf(c)
	return c:IsFaceup() and c:IsMonster() and c:HasLevel() and c:GetLevel()%2==0
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c~=chkc and s.unionf(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.unionf,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.unionf,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToEffect(e) or (c:IsLocation(LOCATION_MZONE) and c:IsFacedown()) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and Duel.Equip(tp,c,tc,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
	else
		Duel.SendtoGrave(c,REASON_RULE)
	end
end

function s.mattg(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	return c==ec
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsCanChangePosition() and c:HasLevel() and c:GetFlagEffect(id)<math.floor(c:GetLevel()/2)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.PositionChange(c)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.cf(c,ec)
	return c==ec
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsExists(s.cf,1,nil,ec)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local info =	function(g,e,tp)
						ec:CreateEffectRelation(e)
						Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
					end
	return aux.Target(s.filter,LOCATION_MZONE,LOCATION_MZONE,1,1,ec,false,info)(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=c:GetEquipTarget()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.PositionChange(tc)>0 and tc:GetPreviousPosition()~=tc:GetPosition() and c and c:IsRelateToEffect(e) and ec and ec:IsRelateToEffect(e) then
		local b1=(Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		local opt=aux.Option(id,tp,3,b1,true)
		if opt==0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and ec:IsRelateToEffect(e) then
			Duel.Destroy(ec,REASON_EFFECT)
		elseif opt==1 then
			ec:UpdateATK(600,true,c)
		end
	end
end