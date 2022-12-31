--Gust VINE Rotoraffloci
function c16000889.initial_effect(c)
		 c:EnableReviveLimit()
		local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetCondition(c16000889.fscondition)
	e0:SetOperation(c16000889.fsoperation)
	c:RegisterEffect(e0)
		--destroy replace (not fully complete)
	 --destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
 e4:SetCountLimit(1)
	e4:SetTarget(c16000889.reptg)
	e4:SetValue(c16000889.repval)
e4:SetOperation(c16000889.desrepop)
	c:RegisterEffect(e4)
	 --remove
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_BATTLED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCondition( c16000889.rmcon)
	e4:SetTarget( c16000889.rmtg)
	e4:SetOperation( c16000889.rmop)
	c:RegisterEffect(e4)
end

function c16000889.ffilter(c)
	return  not c:IsRace(RACE_SPELLCASTER)   and c:IsType(TYPE_MONSTER)
end
function c16000889.fscondition(e,g,gc)
	if g==nil then return true end
	if gc then return false end
	return g:IsExists(c16000889.ffilter,2,nil) and (g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND))
end

function c16000889.fsoperation(e,tp,eg,ep,ev,re,r,rp,gc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	Duel.SetFusionMaterial(eg:FilterSelect(tp,c16000889.ffilter,2,2,nil))
end


function c16000889.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0x885a) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function c16000889.repfilterxxl(c,e)
	return  c:IsAbleToGrave()
end
function c16000889.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	   if chk==0 then return   eg:IsExists(c16000889.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(c16000889.repfilterxxl,tp,LOCATION_DECK,0,3,nil) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c16000889.repval(e,c)
	return c16000889.repfilter(c,e:GetHandlerPlayer())
end
function c16000889.desrepop(e,tp,eg,ep,ev,re,r,rp)
  
	Duel.DiscardDeck(tp,3,REASON_EFFECT+REASON_REPLACE)
end



function  c16000889.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	if tc:IsSetCard(0x885a) and bc:IsStatus(STATUS_BATTLE_DESTROYED) and tc:IsStatus(STATUS_OPPO_BATTLE) then
		e:SetLabelObject(bc)
		return true
	else return false end
end
function  c16000889.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0)
end
function  c16000889.rmop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsAbleToRemove() then
	Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	Duel.Recover(tp,bc:GetAttack(),REASON_EFFECT)
end
end