--Yiggy
local ref,id=GetID()
function ref.initial_effect(c)
	c:EnableReviveLimit()
	local magick=Effect.CreateEffect(c)
	magick:SetType(EFFECT_TYPE_TRIGGER_O)
	magick:SetProperty(EFFECT_FLAG_DELAY)
	magick:SetTarget(ref.tgtg)
	magick:SetOperation(ref.tgop)
	aux.AddMagickProcEvent(c,EVENT_ATTACK_ANNOUNCE,nil,aux.MagickMatCost,magick,aux.FilterBoolFunction(Card.IsType,TYPE_TRAP),1)
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),nil,1)
	--ReSet
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.settg)
	e1:SetOperation(ref.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
	c:RegisterEffect(e2)
	--Targetproof
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end

function ref.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=Duel.GetAttacker()
	if chk==0 then return atk~=nil and atk:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,atk,1,0,0)
end
function ref.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(Duel.GetAttacker(),REASON_EFFECT)
end

--ReSet
function ref.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
function ref.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(ref.setfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,ref.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function ref.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tc:RegisterEffect(e1)
	end
end
