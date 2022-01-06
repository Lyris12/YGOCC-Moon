--Dimenticalgia Angelo Joan
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cid.spcon)
	e1:SetCost(cid.spcost)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_LP_CHANGE)
	e1x:SetCondition(cid.spcon2)
	c:RegisterEffect(e1x)
	--apply effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetTarget(cid.tgtg)
	e2:SetOperation(cid.tgop)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,5))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
end
--filters
function cid.filter(c)
	return c:IsSetCard(0xf45) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.cfilter(c)
	return c:IsSetCard(0xf45) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function cid.tgfilter(c)
	return c:GetFlagEffect(id+100)<=0 and c:IsFaceup()
end
function cid.tgtfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
--spsummon
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and (bit.band(r,REASON_BATTLE)~=0 or (bit.band(r,REASON_EFFECT)~=0)) and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function cid.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev<0 and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function cid.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)<=0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.abs(ev*2))
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Recover(tp,math.abs(ev*2),REASON_EFFECT)
	end
end
--apply effects
function cid.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and cid.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function cid.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetFlagEffect(id+100)<=0 and tc:IsControler(1-tp) then
		local fid=e:GetHandler():GetFieldID()
		e:GetHandler():RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE,1,fid)
		tc:RegisterFlagEffect(id+200,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		tc:RegisterFlagEffect(id+300,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		tc:RegisterFlagEffect(id+400,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,4))
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetLabelObject(tc)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetLabel(1-tp)
		e2:SetLabelObject(e1)
		e2:SetCondition(cid.atlimitcon)
		e2:SetTarget(cid.atlimittarg)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_MUST_ATTACK)
		e3:SetLabelObject(e2)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
		e4:SetLabel(fid)
		e4:SetLabelObject(e3)
		e4:SetValue(cid.atklimit)
		tc:RegisterEffect(e4)
		--reset
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e5:SetCode(EVENT_ADJUST)
		e5:SetLabel(fid)
		e5:SetLabelObject(e4)
		e5:SetCondition(cid.resetcon)
		e5:SetOperation(cid.resetop)
		Duel.RegisterEffect(e5,tp)
	end
end
function cid.atlimitcon(e)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()==e:GetLabel() and Duel.GetCurrentPhase()>PHASE_MAIN1 and Duel.GetCurrentPhase()<PHASE_MAIN2 and c:GetAttackAnnouncedCount()==0
end
function cid.atlimittarg(e,c)
	return c~=e:GetHandler()
end
function cid.atklimit(e,c)
	return c:GetFlagEffect(id+100)>0 or c:GetFlagEffectLabel(id+100)==e:GetLabel()
end
--reset
function cid.retfilter(c,fid)
	return c:GetFlagEffectLabel(id+100)==fid
end
function cid.resetcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler()
	return g:GetFlagEffect(id+100)<=0 or g:GetFlagEffectLabel(id+100)~=e:GetLabel()
end
function cid.resetop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject():GetLabelObject():GetLabelObject():GetLabelObject()
	local e1=e:GetLabelObject():GetLabelObject():GetLabelObject():GetLabelObject()
	local e2=e:GetLabelObject():GetLabelObject():GetLabelObject()
	local e3=e:GetLabelObject():GetLabelObject()
	local e4=e:GetLabelObject()
	e1:Reset()
	e2:Reset()
	e3:Reset()
	e4:Reset()
	--reset flags
	if tc:GetFlagEffect(id+200)>0 then
		tc:ResetFlagEffect(id+200)
		tc:ResetFlagEffect(id+300)
		tc:ResetFlagEffect(id+400)
	end
	-------------
	e:Reset()
end
--search
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
			Duel.ConfirmCards(1-tp,g)
			if Duel.GetTurnPlayer()==1-tp and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local g2=Duel.GetMatchingGroup(cid.tgtfilter,tp,LOCATION_DECK,0,nil)
				if g2:GetCount()>0 then
					local tc=g2:Select(tp,1,1,nil)
					Duel.SendtoGrave(tc,REASON_EFFECT)
				else
					Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,LOCATION_DECK,0))
					Duel.ShuffleDeck(tp)
				end
			end
		end
	end
end