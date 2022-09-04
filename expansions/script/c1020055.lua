--created by Jake
--Bushido Legend Griffin
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--mat=2 "Bushido" monsters
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x4b0),2,2)
	--Unaffected by the effect(s) of Special Summoned monsters your opponent controls.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.unval)
	c:RegisterEffect(e1)
	--You can only Link Summon "Bushido Legend Griffin" once per turn.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.sumcon)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	--During your Main Phase, you can Normal Summon 1 "Bushido" monster in addition to your Normal Summon/Set. (You can only gain this effect once per turn.)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4b0))
	c:RegisterEffect(e1)
	--If a "Bushido" monster is Normal or Special Summoned to a zone this card points to: Gain LP equal to that monster's original Level/Rank x200.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48964966,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(s.rectg)
	e3:SetOperation(s.recop)
	c:RegisterEffect(e3)
	local e5=e3:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
function s.unval(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b0) and (c:GetOriginalLevel()>0 or c:GetOriginalRank()>0)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.filter,nil)
	if chk==0 then return g:GetCount()==1 end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,0)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:Filter(s.filter,nil):GetFirst()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=tc:GetOriginalLevel()>0 and tc:GetOriginalLevel() or tc:GetOriginalRank()
		Duel.Recover(tp,lv*200,REASON_EFFECT)
	end
end
