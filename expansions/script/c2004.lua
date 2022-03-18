--Y-Ergoriesumato Jetlagcodice
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	--extra material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(0,LOCATION_MZONE)
	e0:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_ANONYMIZE))
	e0:SetValue(s.matval)
	c:RegisterEffect(e0)
	--act limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition1)
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)
	--atkchange
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetLabelObject(e1)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--attack
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCost(s.atkcost)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
function s.lcheck(g,lc)
	local cmp=0
	local extraslot=true
	for c in aux.Next(g) do
		if extraslot and c:IsCode(CARD_ANONYMIZE) and c:IsControler(1-self_reference_effect:GetHandlerPlayer()) and c:IsLocation(LOCATION_MZONE) then
			extraslot=false
		else
			local n=tostring(c:GetOriginalCode())
			local d=n:sub(1,1)
			if cmp==0 then
				cmp=d
			else
				if cmp~=d then
					return false
				end
			end
		end
	end
	return true
end
function s.excfilter(c,tp)
	return c:IsCode(CARD_ANONYMIZE) and c:IsControler(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	return true, not mg or not mg:IsExists(s.excfilter,1,nil,tp)
end

function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	local l1=e:GetLabel()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and l1>0
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc and rc:GetOriginalCode()<e:GetLabel() then
		Duel.SetChainLimit(s.limit(e:GetLabel()))
	end
end
function s.limit(val)
	return	function (e,lp,tp)
				return e:GetHandler():GetOriginalCode()<=val
			end
end

function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local l1,l2=e:GetLabel()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and l1>0 and l2==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		local _,val=g:GetMaxGroup(Card.GetCode)
		val=val-math.fmod(val,50)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
end
function s.countop(e)
	if e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) then
		e:GetHandler():SetHint(CHINT_NUMBER,e:GetLabel())
	end
	e:Reset()
end
function s.codecheck(c)
	return c:GetOriginalCode()>999 and c:GetOriginalCode()<10000
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if not g then
		e:GetLabelObject():SetLabel(0)
		e:GetLabelObject():GetLabelObject():SetLabel(0)
	else
		local ct=g:GetSum(Card.GetOriginalCode)
		e:GetLabelObject():SetLabel(ct)
		e:GetLabelObject():GetLabelObject():SetLabel(ct)
		local e0=Effect.CreateEffect(c)
		e0:SetDescription(aux.Stringid(id,2))
		e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_SPSUMMON_SUCCESS)
		e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetLabel(ct)
		e0:SetOperation(s.countop)
		c:RegisterEffect(e0)		
	end
	local lab=e:GetLabelObject():GetLabel()
	if g:IsExists(s.codecheck,3,nil) then
		e:GetLabelObject():SetLabel(lab,1)
	else
		e:GetLabelObject():SetLabel(lab,0)
	end
end

function s.cf(c)
	return aux.NegateAnyFilter(c) and not c:IsOriginalSetCard(0xca4)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local b2=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,0,nil)
	local nc=b2:GetFirst()
	while nc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		nc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		nc:RegisterEffect(e2)
		if nc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			nc:RegisterEffect(e3)
		end
		nc=b2:GetNext()
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,1-tp)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_DECK,nil,1-tp)
	local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil,1-tp)
	if g1:GetCount()>0 and g2:GetCount()>0 and g3:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg1=g1:Select(1-tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg2=g2:Select(1-tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg3=g3:Select(1-tp,1,1,nil)
		sg1:Merge(sg2)
		sg1:Merge(sg3)
		Duel.HintSelection(sg1)
		if Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)==3 and sg1:IsExists(Card.IsLocation,3,nil,LOCATION_REMOVED) and Duel.NegateAttack() then
			local c=e:GetHandler()
			if not c or not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
			local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			if #g>0 then
				Duel.BreakEffect()
				local _,val=g:GetMaxGroup(Card.GetCode)
				val=val-math.fmod(val,50)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetValue(val)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
	end
end