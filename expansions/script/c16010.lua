--Paracyclis Spider Queen, Tsuropsia
--Automate ID
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)>1
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.spop(e,tp)
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tg=Duel.SelectTarget(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,3,nil,POS_FACEDOWN_DEFENSE)
		for tc in aux.Next(tg) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCondition(function(e) return Duel.GetTurnCount()>e:GetLabel() end)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
			e1:SetLabel(Duel.GetTurnCount())
			tc:RegisterEffect(e1)
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	e:GetHandler():SetHint(CHINT_CARD,ac)
	local g=Duel.GetMatchingGroup(Card.IsCode,1-tp,LOCATION_EXTRA,0,nil,ac)
	if #g>0 then
		if #g>1 then
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
			rg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil)
		else
			rg=g:Clone()
		end
		if #rg~=0 then
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
