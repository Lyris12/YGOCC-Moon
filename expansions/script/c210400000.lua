--created & coded by Lyris, art from Cardfight!! Vanguard's Soul Charge
--ソウルチャージ
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	c:SetUniqueOnField(1,0,id,LOCATION_SZONE)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCountLimit(3)
	e2:SetLabel(0)
	e2:SetCondition(cid.checkop)
	e2:SetTarget(cid.attg)
	e2:SetOperation(cid.atop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetLabel(1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(cid.sdcon)
	c:RegisterEffect(e4)
	if not cid.global_check then
		cid.global_check=true
		cid[0]=aux.Stringid(id,0)
		cid[1]=aux.Stringid(id,1)
	end
end
function cid.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	return re:IsActiveType(TYPE_XYZ) and tc:IsLocation(LOCATION_ONFIELD) and tc:IsControler(e:GetLabel())
end
function cid.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.Hint(HINT_OPSELECTED,0,cid[rp])
	local tc=Group.FromCards(re:GetHandler())
	Duel.HintSelection(tc)
	Duel.SetTargetCard(tc)
end
function cid.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
	local p=e:GetLabel()
	local g=Duel.GetDecktopGroup(p,1)
	if g:GetCount()==0 then return end
	Duel.DisableShuffleCheck()
	Duel.Overlay(tc,g)
	local ap=0x0+p+0x1
	local ct=c:GetFlagEffectLabel(id)
	if not ct then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,ap)
	else
		c:SetFlagEffectLabel(id,bit.bor(ap,ct))
	end
end
function cid.sdcon(e)
	local c=e:GetHandler()
	return c:GetFlagEffect(id)>0 and bit.band(c:GetFlagEffectLabel(id),0x3)==0x3
end
