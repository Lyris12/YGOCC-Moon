--Vacuoseguace dell'Oscurità
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.drawcon)
	e1:SetOperation(s.drawop)
	c:RegisterEffect(e1)
	--equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equipop,e2)
end

function s.dfil(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousTypeOnField()&TYPE_MONSTER>0 and c:GetPreviousAttributeOnField()&ATTRIBUTE_DARK>0
end
function s.cfilter(c)
	return c:IsReason(REASON_EFFECT)
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	if eg:IsExists(s.dfil,1,nil) then
		return true
	end
	if des:IsReason(REASON_BATTLE) then
		local rc=des:GetReasonCard()
		return rc and rc:IsMonster() and rc:IsFaceup() and rc:IsAttribute(ATTRIBUTE_DARK) and rc:IsLocation(LOCATION_MZONE) and rc:IsRelateToBattle()
	elseif re then
		local rc=re:GetHandler()
		return eg:IsExists(s.cfilter,1,nil) and rc and rc:IsAttribute(ATTRIBUTE_DARK) and rc:IsOnField() and re:IsActiveType(TYPE_MONSTER)
	end
	return false
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Draw(tp,1,REASON_EFFECT)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.BreakEffect()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

function s.eqval(ec,c,tp)
	return s.eqfilter(ec)
end
function s.eqfilter(c)
	return c:IsMonster() and c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_DARK) and not c:IsForbidden() and c:NotBanishedOrFaceup()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_REMOVED,1,nil)
	end
end
function s.equipop(c,e,tp,tc)
	aux.EquipByEffectAndLimitRegister(c,e,tp,tc,id,true)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_REMOVED,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		if aux.EquipByEffectAndLimitRegister(c,e,tp,tc,id,true) then
			local code=tc:GetOriginalCode()
			local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY,1)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY,0,0)
			local e0=Effect.CreateEffect(c)
			e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e0:SetCode(id)
			e0:SetLabel(code)
			e0:SetLabelObject(tc)
			e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
			c:RegisterEffect(e0,true)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_ADJUST)
			e1:SetRange(LOCATION_MZONE)
			e1:SetLabel(cid)
			e1:SetLabelObject(e0)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e1:SetOperation(s.resetop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
			c:RegisterEffect(e1,true)
		end
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetEquipGroup():FilterCount(Card.HasFlagEffect,nil,id)<=0 then
		c:ResetEffect(e:GetLabel(),RESET_COPY)
		e:GetLabelObject():Reset()
		e:Reset()
	end
end