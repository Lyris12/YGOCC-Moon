--Stardust Sifr Ascension Dragon
--Scripted by: Unknown
--Updated by: Glitchy

local s,id,o=GetID()
function s.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.FilterBoolFunction(Card.IsCode,83994433),1,1)
	c:EnableReviveLimit()
	--protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetValue(s.indval(REASON_EFFECT))
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.indval(REASON_BATTLE))
	c:RegisterEffect(e2)
	--Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)	
end
function s.indval(res)
	return	function(e,re,r,rp)
				return r&res~=0
			end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainDisablable(ev) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(aux.PLChk,1,nil,tp,LOCATION_ONFIELD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local relation=rc:IsRelateToChain(ev)
	if chk==0 then return c:IsAbleToRemove(tp) and (rc:IsAbleToRemove(tp) or (not relation and Duel.IsPlayerCanRemove(tp))) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,Group.FromCards(c,rc),2,PLAYER_ALL,LOCATION_MZONE|rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,c:GetControler(),LOCATION_MZONE|rc:GetPreviousLocation())
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
		if c:IsBanished() then
			local fid=e:GetFieldID()
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE,1,fid)
			local e2=Effect.CreateEffect(c)
			e2:Desc(1)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetCountLimit(1)
			e2:SetLabel(fid)
			e2:SetLabelObject(c)
			e2:SetCondition(s.spcon)
			e2:SetOperation(s.spop)
			Duel.RegisterEffect(e2,tp)
		end
		if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.spcon(e)
	local fid=e:GetLabel()
	local c=e:GetLabelObject()
	if not c or not c:HasFlagEffectLabel(id,fid) then
		e:Reset()
		return false
	end
	return true
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetLabel()
	local c=e:GetLabelObject()
	if c and c:HasFlagEffectLabel(id,fid) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,c:GetControler(),false,false,POS_FACEUP)
	end
end