--created by Walrus, coded by XGlitchy30
--Voidictator Rune - Gates of Perdition
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetCategory(CATEGORY_REMOVE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:HOPT(true)
	e0:SetTarget(s.target)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atktg)
	e3:SetValue(s.value)
	c:RegisterEffect(e3)
	e3:UpdateDefenseClone(c)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.immcon)
	e4:SetTarget(s.atktg)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if ct==0 then return end
	local nums={}
	for i=1,math.min(ct,Duel.GetDeckCount(tp)) do
		local dg=Duel.GetDecktopGroup(tp,i)
		if not dg:IsExists(aux.NOT(Card.IsAbleToRemove),1,nil) then
			table.insert(nums,i)
		end
	end
	if #nums>0 and not Duel.PlayerHasFlagEffect(tp,id) and Duel.SelectYesNo(tp,STRING_ASK_BANISH) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local n=Duel.AnnounceNumber(tp,table.unpack(nums))
		local g=Duel.GetDecktopGroup(tp,n)
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(ARCHE_VOIDICTATOR)
end
function s.atktg(e,c)
	return c:IsSetCard(ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON)
end
function s.value(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,ARCHE_VOIDICTATOR_DEITY,ARCHE_VOIDICTATOR_DEMON),tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetOriginalCodeRule)*300
end
function s.immcon(e)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):Filter(Card.IsFaceup,nil)
	return g:IsExists(Card.IsSetCard,1,nil,ARCHE_VOIDICTATOR_DEITY) and g:IsExists(Card.IsSetCard,1,nil,ARCHE_VOIDICTATOR_DEMON) and g:IsExists(Card.IsSetCard,1,nil,ARCHE_VOIDICTATOR_SERVANT)
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
