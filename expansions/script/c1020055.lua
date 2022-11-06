--Leggenda Bushido Grifone
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x4b0),2)
	--protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--normal summon
	c:Ignition(0,CATEGORY_SUMMON,nil,nil,true,
		nil,
		aux.ToDeckCost(aux.FilterBoolFunction(Card.IsSetCard,0x4b0),LOCATION_GRAVE),
		aux.NSTarget(aux.FilterBoolFunction(Card.IsSetCard,0x4b0),LOCATION_HAND),
		aux.NSOperation(aux.FilterBoolFunction(Card.IsSetCard,0x4b0),LOCATION_HAND)
	)
	--If a "Bushido" monster is Normal or Special Summoned to a zone this card points to: Gain LP equal to that monster's original Level/Rank x200.
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:HOPT()
	e3:SetCondition(s.reccon)
	e3:SetTarget(s.rectg)
	e3:SetOperation(s.recop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and tc:IsOnField() and (tc:IsSummonType(SUMMON_TYPE_SPECIAL) or te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.filter(c,cc)
	return c:IsFaceup() and c:IsSetCard(0x4b0) and (c:GetOriginalLevel()>0 or c:GetOriginalRank()>0)
		and c:HasBeenInLinkedZone(cc)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,e:GetHandler())
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.filter,nil,e:GetHandler()):Filter(Card.IsLocation,nil,LOCATION_MZONE)
	if chk==0 then return true end
	Duel.SetTargetCard(g)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(Card.IsFaceup,nil)
	if #g>0 then
		if #g>1 then
			Duel.HintMessage(HINTMSG_FACEUP)
			g=g:Select(tp,1,1,nil)
		end
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local lv=tc:GetOriginalLevel()>0 and tc:GetOriginalLevel() or tc:GetOriginalRank()>0 and tc:GetOriginalRank()
		if lv>0 then
			Duel.Recover(tp,lv*200,REASON_EFFECT)
		end
	end
end
